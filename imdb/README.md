# IMDB dataset experiments

#### 1. Generating graphs
```
$ sh graphgen.sh
```

#### 2. Learning embeddings with sensitivity task 
```
$ sh sample_sensi.sh
```

#### 3. Classification task
```
$ sh classification.sh
```

#### 4. Retrieval task
```
$ sh retrieval_ice.sh
$ sh retrieval_baselines.sh
```

#### 5. Drawing sctter plots
i. Open the ipython notebook service in server side:
```
(server) $ ipython notebook --no-browser --port=8889
```

ii. Bridge the client side to the service:
```
(client) $ ssh -N -f -L localhost:8888:localhost:8889 [user_id]@[server_ip]
```

iii. Open the scatter_plot.ipynb through client's browser (url=localhost:8888)

#### 6. Case study
i. % ii. are the same as in Section 5.

iii. Open the case_study.ipynb through client's browser (url=localhost:8888)
