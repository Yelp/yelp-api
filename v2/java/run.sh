#!/bin/sh

EXAMPLE_CP=lib/commons-codec-1.4.jar:lib/scribe-1.1.0.jar:.

mkdir -p build && javac -classpath $EXAMPLE_CP -d build Yelp.java && java -classpath $EXAMPLE_CP:build Yelp