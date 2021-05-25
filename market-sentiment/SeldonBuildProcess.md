## Building the Seldon Deployment

Many of the steps used in the creation of this deployment were found in the [Spacy Example](https://docs.seldon.io/projects/seldon-core/en/latest/examples/sklearn_spacy_text_classifier_example.html). 

If you want to run the current compiled example, jump to Step 3. 


1. Download and extract the model (and config) from train_model to this directory (`market-sentiment/trained_model/config.json`, etc.). This model will be packaged up in the container.

https://drive.google.com/file/d/1q7A-XePDn8S9iCuYrEGFMoNwQ-S9ln4H/view?usp=sharing

2. Build Docker container 

```bash
docker build . -f Dockerfile.seldon -t jimmywhitaker/seldon-core-hugging-face-base:0.6
```

3. Create and package entrypoint inside Docker image with S2I config

```bash
s2i build . jimmywhitaker/seldon-core-hugging-face-base:0.4 jimmywhitaker/market-sentiment-classifier:0.6
```

3. Test the model (running as root)

Run the server:
```
docker run --name "market-sentiment-classifier" -d --rm -p 9001:9000 jimmywhitaker/market-sentiment-classifier:0.6
```

Send sentiment analysis request:  
```
curl -v -X POST -H 'Content-Type: application/json'    -d '{"data": { "ndarray": "The CBOE Volatility Index (VIX) is at 19.93. This is a positive reading and indicates that market risks appear low.", "names": ["text"] } }' http://localhost:9001/api/v1.0/predictions
```

4. Push the docker image to your registry. 

```
docker push jimmywhitaker/market-sentiment-classifier:0.6
```

5. Use the Seldon UI to deploy the model. 
<!-- 
4. [Error] Running the server not as root

Run the server:
```
docker run -it --user 8888 --name "market-sentiment-classifier" --rm --entrypoint=/bin/bash -p 9001:9000 jimmywhitaker/market-sentiment-classifier:0.4
```

Send sentiment analysis request:  
```
curl -v -X POST -H 'Content-Type: application/json'    -d '{"data": { "ndarray": "The CBOE Volatility Index (VIX) is at 19.93. This is a negative reading and indicates that market risks appear low.", "names":["text"] } }' http://localhost:9001/api/v1.0/predictions
```

Server error: 
```
[Errno 13] Permission denied: '/.cache'
2021-05-20 20:42:05,545 - seldon_core.wrapper:log_exception:1892 - ERROR:  Exception on /predict [POST]
Traceback (most recent call last):
  File "/opt/conda/lib/python3.7/site-packages/transformers/configuration_utils.py", line 492, in get_config_dict
    user_agent=user_agent,
  File "/opt/conda/lib/python3.7/site-packages/transformers/file_utils.py", line 1279, in cached_path
    local_files_only=local_files_only,
  File "/opt/conda/lib/python3.7/site-packages/transformers/file_utils.py", line 1426, in get_from_cache
    os.makedirs(cache_dir, exist_ok=True)
  File "/opt/conda/lib/python3.7/os.py", line 211, in makedirs
    makedirs(head, exist_ok=exist_ok)
  File "/opt/conda/lib/python3.7/os.py", line 211, in makedirs
    makedirs(head, exist_ok=exist_ok)
  File "/opt/conda/lib/python3.7/os.py", line 221, in makedirs
    mkdir(name, mode)
PermissionError: [Errno 13] Permission denied: '/.cache'

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/opt/conda/lib/python3.7/site-packages/flask/app.py", line 2447, in wsgi_app
    response = self.full_dispatch_request()
  File "/opt/conda/lib/python3.7/site-packages/flask/app.py", line 1952, in full_dispatch_request
    rv = self.handle_user_exception(e)
  File "/opt/conda/lib/python3.7/site-packages/flask_cors/extension.py", line 165, in wrapped_function
    return cors_after_request(app.make_response(f(*args, **kwargs)))
  File "/opt/conda/lib/python3.7/site-packages/flask/app.py", line 1821, in handle_user_exception
    reraise(exc_type, exc_value, tb)
  File "/opt/conda/lib/python3.7/site-packages/flask/_compat.py", line 39, in reraise
    raise value
  File "/opt/conda/lib/python3.7/site-packages/flask/app.py", line 1950, in full_dispatch_request
    rv = self.dispatch_request()
  File "/opt/conda/lib/python3.7/site-packages/flask/app.py", line 1936, in dispatch_request
    return self.view_functions[rule.endpoint](**req.view_args)
  File "/microservice/python/seldon_core/wrapper.py", line 64, in Predict
    user_model, requestJson, seldon_metrics
  File "/microservice/python/seldon_core/seldon_methods.py", line 140, in predict
    user_model, features, class_names, meta=meta
  File "/microservice/python/seldon_core/user_model.py", line 237, in client_predict
    client_response = user_model.predict(features, feature_names, **kwargs)
  File "/microservice/SentimentClassifier.py", line 45, in predict
    result = finbert.predict(text,self._classification_model)
  File "/microservice/finbert/finbert.py", line 722, in predict
    tokenizer = AutoTokenizer.from_pretrained("bert-base-uncased")
  File "/opt/conda/lib/python3.7/site-packages/transformers/models/auto/tokenization_auto.py", line 402, in from_pretrained
    config = AutoConfig.from_pretrained(pretrained_model_name_or_path, **kwargs)
  File "/opt/conda/lib/python3.7/site-packages/transformers/models/auto/configuration_auto.py", line 430, in from_pretrained
    config_dict, _ = PretrainedConfig.get_config_dict(pretrained_model_name_or_path, **kwargs)
  File "/opt/conda/lib/python3.7/site-packages/transformers/configuration_utils.py", line 504, in get_config_dict
{"level":"info","ts":1621543188.3688786,"logger":"entrypoint","msg":"Hostname unset will use localhost"}
{"level":"info","ts":1621543188.3736403,"logger":"entrypoint","msg":"Starting","worker":1}
{"level":"info","ts":1621543188.3736842,"logger":"entrypoint","msg":"Starting","worker":2}
{"level":"info","ts":1621543188.3736894,"logger":"entrypoint","msg":"Starting","worker":3}
{"level":"info","ts":1621543188.3736932,"logger":"entrypoint","msg":"Starting","worker":4}
{"level":"info","ts":1621543188.3737016,"logger":"entrypoint","msg":"Starting","worker":5}
{"level":"info","ts":1621543188.3749442,"logger":"entrypoint","msg":"Running http server ","port":8000}
{"level":"info","ts":1621543188.3749719,"logger":"entrypoint","msg":"Creating non-TLS listener","port":8000}
{"level":"info","ts":1621543188.3751822,"logger":"entrypoint","msg":"Running grpc server ","port":5001}
{"level":"info","ts":1621543188.375194,"logger":"entrypoint","msg":"Creating non-TLS listener","port":5001}
{"level":"info","ts":1621543188.3752158,"logger":"entrypoint","msg":"Setting max message size ","size":2147483647}
{"level":"info","ts":1621543188.3774385,"logger":"SeldonRestApi","msg":"Listening","Address":"0.0.0.0:8000"}
Work request queued
worker1: Received work request for http://broker-ingress.knative-eventing.svc.cluster.local/seldon-logs/default
{"level":"info","ts":1621543325.5529766,"logger":"JSONRestClient","msg":"httpPost failed","response code":500}
    raise EnvironmentError(msg)
OSError: Can't load config for 'bert-base-uncased'. Make sure that:

- 'bert-base-uncased' is a correct model identifier listed on 'https://huggingface.co/models'

- or 'bert-base-uncased' is the correct path to a directory containing a config.json file
``` -->
