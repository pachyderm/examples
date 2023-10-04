import duckdb
from skimage import io
import plotly.express as px
import plotly.graph_objects as pgo
from plotly.subplots import make_subplots
import plotly.io as pio

pio.kaleido.scope.chromium_args += ("--single-process",)

INPUT_PATH = "/pfs/predict-catdog/*/data/*.csv"
OUTPUT_PATH = "/pfs/out"
DB_PATH = f"{OUTPUT_PATH}/results.duckdb"
DB_PATH_CSV = f"{OUTPUT_PATH}/results.csv"
STATS_PATH = f"{OUTPUT_PATH}/stats"

def save_db_results(db):
    db.execute("""
        CREATE TABLE IF NOT EXISTS results (
            file_path VARCHAR UNIQUE,
            file_name VARCHAR,
            model VARCHAR,
            prediction VARCHAR,
            probability DECIMAL(18,10),
            confidence_dog DECIMAL(18,10),
            confidence_cat DECIMAL(18,10),
            start_time TIMESTAMP,
            end_time TIMESTAMP,
            hostname VARCHAR
        );
    """)
    db.execute(f"INSERT OR REPLACE INTO results SELECT * FROM read_csv_auto('{INPUT_PATH}');")
    db.execute(f"COPY results TO '{DB_PATH_CSV}' (HEADER, DELIMITER ',');")

def save_stats(db):
  df = db.execute("SELECT * from results").df()

  # Bar chart of prediction counts
  fig = px.bar(df.prediction, x='prediction', color="prediction")
  fig.update_layout(showlegend=False)
  fig.write_image(f"{OUTPUT_PATH}/bar.png")

  # Bar chart of workloads for each hostname
  fig = px.bar(df.hostname, x='hostname', color="hostname")
  fig.update_layout(showlegend=False)
  fig.write_image(f"{OUTPUT_PATH}/hosts.png")

  # Scatter plot of probabilities for each image/model
  fig = px.scatter(df, x="file_name", y="probability", color="model")
  fig.update_xaxes(visible=False, showticklabels=False)

  for idx, row in df.nsmallest(5, 'probability').iterrows():
    fig.add_annotation( # Label the worst probabilities
      x=row.file_name,
      y=row.probability,
      text=row.file_name
    )

  fig.write_image(f"{OUTPUT_PATH}/scatter.png")

  # Show the worst n performers for each model
  n_worst = 3
  n_models = df.model.nunique()
  grouped_by_model = df.groupby("model").apply(lambda x: x.nsmallest(n_worst, "probability"))
  subplot_titles = [
     f"{row.model}/{row.file_name}<br>{row.prediction} {'{:.4f}%'.format(row.probability * 100)}" for idx, row in grouped_by_model.iterrows()
  ]

  fig = make_subplots(rows=n_models, cols=n_worst, subplot_titles=subplot_titles)
  fig.update_layout(autosize=False, width=1000, height=1000)
  x, y = [1, 1]

  for idx, row in grouped_by_model.iterrows():
     image = io.imread(row.file_path.replace("/pfs/out", "/pfs/predict-catdog"))
     fig.add_trace(pgo.Image(z=image), x, y)
     fig.update_xaxes(visible=False)
     fig.update_yaxes(visible=False)

     y = y + 1

     if y > n_worst:
        y = 1
        x = x + 1

  fig.write_image(f"{OUTPUT_PATH}/hall_of_shame.png")

def save_results():
    db = duckdb.connect(DB_PATH)

    save_db_results(db)
    save_stats(db)
    db.close()

save_results()
