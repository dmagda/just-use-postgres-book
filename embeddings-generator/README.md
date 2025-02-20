# Embeddings Generator for OMDB Movies Dataset

This embeddings generator creates embeddings for the OMDB movies dataset and sample phrases used for similarity search.
The dataset is used in Chapter 8, Postgres for AI. 

You can use this tool if you'd like to regenerate embeddings using a different embedding model or create embeddings for new phrases.

## Prerequisites

1. Create an [OpenAI account](http://platform.openai.com/) and provide your API key in the `.env` file.
2. Install Node.js and NPM.
3. Connect to Postgres and preload the OMDB movies dataset located in the `data/movie_pgvector` directory.

## Initialize Project

Initialize the project downloading required modules:
```shell
npm install
```

## Generate Movie Embeddings

Run the following command to generate movie embeddings using an OpenAI embedding model:

```shell
node index.js generateMovieEmbeddings
```

The embeddings will be stored in the `movie_embedding` column of the `omdb.movies` table.

## Generate Phrase Embeddings

The book uses a pre-created dictionary of phrases with corresponding embeddings. The dictionary is stored in the `omdb.phrases_dictionary` table, and an embedding can be retrieved by passing a phrase to the `get_embedding(input_phrase TEXT)` database function.

Run the following command to generate the dictionary:

```shell
node index.js generatePhraseEmbeddings
```

You can update the list of phrases in the `generatePhraseEmbeddings` function within the index.js script.

## Testing Similarity Search

The `index.js` script provides two functions to perform similarity searches for a given phrase.

The first function uses cosine distance:
```shell
node index.js testCosineSimilaritySearch="<phrase>"
```

The second function uses Euclidean distance:
```shell
node index.js testEuclideanSimilaritySearch="<phrase>"
```