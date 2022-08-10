import argparse
import streamlit as st
from PIL import Image

parser = argparse.ArgumentParser(description="Serve image from PFS")
parser.add_argument("--image-path", type=str, help="")

st.set_page_config(
     page_title="Data Preview",
     page_icon="🧊",
     layout="wide",
     initial_sidebar_state="expanded",
     menu_items={
         'Get Help': 'https://developers.snowflake.com',
         'About': "This is dev app by Jimmy."
     }
 )


if __name__ == "__main__":
    args = parser.parse_args()
    image = Image.open(args.image_path)

    st.image(image, caption='Image from '+ str(args.image_path))