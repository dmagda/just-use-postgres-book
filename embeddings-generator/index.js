import dotenv from "dotenv";
import OpenAI from "openai";
import pg from "pg";
const { Pool } = pg;

dotenv.config();

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log(`No arguments provided. Available arguments:
      - generateMovieEmbeddings
      - generatePhraseEmbeddings
      - testCosineSimilaritySearch="<phrase>"
      - testEuclideanSimilaritySearch="<phrase>"`);

    process.exit();
  }
  
  for (const arg of args) {
    if (arg.startsWith("testCosineSimilaritySearch=")) {
      let phrase = arg.split("=")[1];
      phrase = phrase.replace(/"/g, ''); // Remove double quotes

      if (!phrase) {
        console.log("Provide a phrase for the cosine similarity search.");
        continue;
      }

      await testCosineSimilaritySearch(phrase);

    } else if (arg.startsWith("testEuclideanSimilaritySearch=")) {
      let phrase = arg.split("=")[1];
      phrase = phrase.replace(/"/g, ''); // Remove double quotes

      if (!phrase) {
        console.log("Provide a phrase for the euclidean similarity search.");
        continue;
      }

      await testEuclideanSimilaritySearch(phrase);

    } else if (arg === "generateMovieEmbeddings") {
      await generateMovieEmbeddings();

    } else if (arg === "generatePhraseEmbeddings") {

      await generatePhraseEmbeddings();
    } else {
      console.log(`Invalid argument: ${arg}. Available arguments:
        - generateMovieEmbeddings
        - generatePhraseEmbeddings
        - testCosineSimilaritySearch="<phrase>"
        - testEuclideanSimilaritySearch="<phrase>"`);
    }
  }

  process.exit();
}

async function generateMovieEmbeddings() {
  console.log("Started generating embeddings for movies...");

  const client = await pool.connect();

  const movies = await client.query(
    "SELECT id, name, description FROM omdb.movies");

  let cnt = 0;

  for (const movie of movies.rows) {
    const { id, name, description } = movie;

    const movieOverview = description ? name + " " + description : name;

    const embedding = await generateEmbedding(movieOverview);
    
    await client.query(
      "UPDATE omdb.movies SET movie_embedding = $1 WHERE id = $2",
      ['[' + embedding.data[0].embedding + ']', id]
    );

    cnt++;
    if (cnt % 10 === 0) {
      console.log(`Processed ${cnt} movies`);
    }
  }

  client.release();

  console.log("Finished generating embeddings for movies");
}

async function generatePhraseEmbeddings() {
  console.log("Started generating embeddings for phrases...");

  const client = await pool.connect();

  const phrases = [
    'May the force be with you',
    'A movie about a Jedi who fights against the dark side of the force',
    'A pirate captain who sails the seven seas in search of treasure',
    'A clown fish who gets lost in the ocean and tries to find his way home',
  ]

  client.query('TRUNCATE TABLE omdb.phrases_dictionary');

  for (const phrase of phrases) {
    const embedding = await generateEmbedding(phrase);
  
    await client.query(
      "INSERT INTO omdb.phrases_dictionary (phrase, phrase_embedding) VALUES ($1, $2)",
      [phrase, '[' + embedding.data[0].embedding + ']']
    );
  }

  client.release();

  console.log("Finished generating embeddings for phrases");
}

async function generateEmbedding(inputText) {
  return await openai.embeddings.create({
    model: "text-embedding-3-small",
    input: inputText,
    dimensions: 1536,
    encoding_format: "float",
  });
}

async function testCosineSimilaritySearch(phrase) {
  const client = await pool.connect();

  const embedding = await generateEmbedding(phrase);

  const result = await client.query(
    "SELECT id, name, description, 1 - (movie_embedding <=> $1) as similarity " +
    "FROM omdb.movies WHERE 1 - (movie_embedding <=> $1) > 0.3 " +
    "ORDER BY similarity DESC LIMIT 3",
    ['[' + embedding.data[0].embedding + ']']
  );

  console.log(`Cosine similarity search, result for phrase "${phrase}"`);
  console.log(result.rows);
  console.log();

  client.release();
}

async function testEuclideanSimilaritySearch(phrase) {
  const client = await pool.connect();

  const embedding = await generateEmbedding(phrase);

  const result = await client.query(
    "SELECT id, name, description, (1 / (1 + (movie_embedding <-> $1))) AS similarity " +
    "FROM omdb.movies " +
    "WHERE (1 / (1 + (movie_embedding <-> $1))) > 0.3 " +
    "ORDER BY similarity DESC LIMIT 3",
    ['[' + embedding.data[0].embedding + ']']
  );

  console.log(`Euclidean similarity search, result for phrase "${phrase}"`);
  console.log(result.rows);
  console.log();

  client.release();
}

await main();