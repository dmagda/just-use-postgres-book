# AI Tools and Samples

You'll find tools and samples used in Chapter 8, Postgres for AI.

## Starting Ollama

First, start an Ollama container in Docker using one of the commands below.

**Unix**:
```shell
mkdir ~/ollama-volume

docker run --name ollama \
    -p 11434:11434 \
    -v ~/ollama-volume:/root/.ollama \
    -d ollama/ollama:0.5.11
```

**Windows** in PowerShell:
```shell
mkdir ~/ollama-volume

docker run --name ollama `
    -p 11434:11434 `
    -v ${PWD}/ollama-volume:/root/.ollama `
    -d ollama/ollama:0.5.11
```

Next, deploy the following models:

* Download the [mxbai-embed-large:335m](https://ollama.com/library/mxbai-embed-large:335m) embedding model:
    ```shell
    docker exec -it ollama ollama pull mxbai-embed-large:335m
    ```

* Download and run the [tinyllama](https://ollama.com/library/tinyllama) LLM:
    ```shell
    docker exec -it ollama ollama pull tinyllama
    ```
    
## Checking Ollama

Once Ollama is started and models are deployed, confirm you can use the models via the [Ollama REST API](https://github.com/ollama/ollama/blob/main/docs/api.md).

**Unix**:

* Check the `tinyllama` LLM:
    ```shell
    curl http://localhost:11434/api/generate -d '{
      "model": "tinyllama",
      "stream": false,
      "prompt":"What is Postgres?"
    }'
    ```

* Check the `mxbai-embed-large:335m` embedding model:
    ```shell
    curl http://localhost:11434/api/embed -d '{
      "model": "mxbai-embed-large:335m",
      "input": "Just Use Postgres!"
    }'
    ```
    
**Windows** in PowerShell:

* Check the `tinyllama` LLM:
    ```shell
    Invoke-RestMethod -Method Post -Uri "http://localhost:11434/api/generate" `
        -Headers @{"Content-Type"="application/json"} `
        -Body '{"model": "tinyllama", "stream": false, "prompt": "What is Postgres?"}'
    ```

* Check the `mxbai-embed-large:335m` embedding model:
    ```shell
    Invoke-RestMethod -Method Post -Uri "http://localhost:11434/api/embed" `
        -Headers @{"Content-Type"="application/json"} `
        -Body '{"model": "mxbai-embed-large:335m", "input": "Just Use Postgres!"}'
    ```

