FROM python:3

WORKDIR /usr/src/site

COPY requirements.txt ./
COPY site/ ./

RUN pip install --no-cache-dir -r requirements.txt
RUN pip install invoke
RUN pip install livereload

RUN chmod +x run.sh

CMD ["/usr/src/site/run.sh"]
