#!/bin/sh

EXAMPLE_CP=lib/scribe-1.3.5.jar:lib/json_simple-1.1.jar:lib/jcommander-1.35.jar:.

mkdir -p build && javac -classpath $EXAMPLE_CP -d build YelpAPI.java && java -classpath $EXAMPLE_CP:build YelpAPI "$@"
