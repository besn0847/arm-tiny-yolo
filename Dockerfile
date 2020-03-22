FROM alpine:3.8
MAINTAINER franck@besnard.mobi 

RUN echo -e '@edge http://nl.alpinelinux.org/alpine/edge/main' \
    >> /etc/apk/repositories

RUN apk add --update --no-cache \
	python3 py2-pip py3-numpy \
	build-base openblas-dev unzip wget cmake libjpeg libjpeg-turbo-dev libpng-dev jasper-dev tiff-dev libwebp-dev clang-dev linux-headers python3-dev

RUN mkdir /data && \
	mkdir /conf && \
	mkdir /bootstrap && \
	rm /usr/bin/python && \
	ln -s /usr/bin/python3.6 /usr/bin/python

RUN pip3 install --upgrade pip && \ 
	pip3 install --upgrade argparse numpy

ENV CC /usr/bin/clang
ENV CXX /usr/bin/clang++
ENV OPENCV_VERSION 3.4.4

RUN mkdir /opt && cd /opt && \
	wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
	unzip ${OPENCV_VERSION}.zip && \
	rm -rf ${OPENCV_VERSION}.zip

RUN mkdir -p /opt/opencv-${OPENCV_VERSION}/build && \
	cd /opt/opencv-${OPENCV_VERSION}/build && \
	cmake \
		-D CMAKE_BUILD_TYPE=RELEASE \
		-D CMAKE_INSTALL_PREFIX=/usr/ \
		-D WITH_FFMPEG=NO \
		-D WITH_IPP=NO \
		-D WITH_OPENEXR=NO \
		-D WITH_TBB=YES \
		-D BUILD_EXAMPLES=NO \
		-D BUILD_ANDROID_EXAMPLES=NO \
		-D INSTALL_PYTHON_EXAMPLES=NO \
		-D BUILD_DOCS=NO \
		-D BUILD_opencv_python2=NO \
		-D BUILD_opencv_python3=ON \
		-D PYTHON3_EXECUTABLE=/usr/bin/python \
		-D PYTHON3_INCLUDE_DIR=/usr/include/python3.6m/ \
		-D PYTHON3_LIBRARY=/usr/lib/libpython3.so \
		-D PYTHON_LIBRARY=/usr/lib/libpython3.so \
		-D PYTHON3_PACKAGES_PATH=/usr/lib/python3.6/site-packages/ \
		-D PYTHON3_NUMPY_INCLUDE_DIRS=/usr/lib/python3.6/site-packages/numpy/core/include/ \
		.. && \
		make VERBOSE=1 && \
		make && \
		make install

 RUN cd /usr/python && \
	python setup.py develop && \
	mkdir /yolo && \
	rm -rf /opt/opencv-${OPENCV_VERSION}/ && \
	pip3 install flask 

RUN apk del --purge \ 
	python3-dev libjpeg-turbo-dev libpng-dev jasper-dev tiff-dev libwebp-dev clang-dev linux-headers build-base openblas-dev unzip wget cmake

RUN apk add --update --no-cache \
	libpng libwebp tiff jasper libstdc++

COPY yolov3-tiny.cfg /yolo/	
COPY yolov3-tiny.txt /yolo/	
COPY yolov3-tiny.weights /yolo/
COPY app.py /yolo/
COPY startup.sh /

RUN chmod +x /startup.sh

EXPOSE 5000

ENTRYPOINT ["/startup.sh"]
