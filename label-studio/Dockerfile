FROM heartexlabs/label-studio:latest

COPY ./label_studio /label-studio/label_studio/
COPY tools/* /label-studio/tools/

RUN python setup.py develop

CMD ["./tools/run-text-example.sh"]