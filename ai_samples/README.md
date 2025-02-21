# AI Tools and Samples

You'll find tools and samples used in Chapter 8, Postgres for AI.

## Starting Ollama

1. Start Ollama in Docker:
    ```shell
    mkdir ~/ollama-volume

    docker run --name ollama \
        -p 11434:11434 \
        -v ~/ollama-volume:/root/.ollama \
        -d ollama/ollama:0.5.11
    ```

    Note, if this image doesn't work for any for some reason, explore [other images in Docker Hub](https://hub.docker.com/r/ollama/ollama).

2. Download the [mxbai-embed-large:335m](https://ollama.com/library/mxbai-embed-large:335m) embedding model:
    ```shell
    docker exec -it ollama ollama pull mxbai-embed-large:335m
    ```

3. Download and run the [tinyllama](https://ollama.com/library/tinyllama) LLM:
    ```shell
    docker exec -it ollama ollama pull tinyllama
    ```

Once Ollama is started and models are deployed, confirm you can use the models via the [Ollama REST API](https://github.com/ollama/ollama/blob/main/docs/api.md).

Check the `tinyllama` LLM:
```shell
curl http://localhost:11434/api/generate -d '{
  "model": "tinyllama",
  "stream": false,
  "prompt":"What is Postgres?"
}'
```

Check the `mxbai-embed-large:335m` embedding model:
```shell
curl http://localhost:11434/api/embed -d '{
  "model": "mxbai-embed-large:335m",
  "input": "Just Use Postgres!"
}'
```
    