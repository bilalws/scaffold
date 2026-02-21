import multiprocessing

bind = "0.0.0.0:8000"
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "gthread"
threads = 2
worker_tmp_dir = "/dev/shm"
timeout = 120
keepalive = 5
accesslog = "runtimes/logs/gunicorn-access.log"
errorlog  = "runtimes/logs/gunicorn-error.log"
loglevel  = "info"
