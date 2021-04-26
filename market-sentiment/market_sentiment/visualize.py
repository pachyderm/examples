from collections import Counter

import matplotlib.pyplot as plt
import seaborn as sns

from wordcloud import WordCloud, STOPWORDS, ImageColorGenerator

def visualize_frequent_words(corpus, stop_words):
    # Check most frequent words which are not in stopwords
    counter = Counter(corpus)
    most = counter.most_common()[:60]
    x, y = [], []
    for word, count in most:
        if word not in stop_words:
            x.append(word)
            y.append(count)

    fig = plt.figure(figsize=(15, 7))
    sns.barplot(x=y, y=x)
    return fig


# Generate Word Cloud image
def generate_word_cloud(corpus, stop_words):
    # Create stopword list:
    stop_words = set(stop_words)
    # stopwords.update(["federal", "federal reserve", "financial", "committee", "market", "would", "also"])

    text = " ".join(corpus)

    # Generate a word cloud image
    wordcloud = WordCloud(
        stopwords=stop_words, max_font_size=50, max_words=100, background_color="white"
    ).generate(text)
    plt.figure(figsize=(15, 7))
    # Display the generated image:
    # the matplotlib way:
    plt.imshow(wordcloud, interpolation="bilinear")
    plt.axis("off")

    # Generate a word cloud image
    wordcloud = WordCloud(stopwords=stop_words, background_color="white").generate(text)
    return wordcloud