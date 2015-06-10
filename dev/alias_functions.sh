drm() { sudo docker rm $(docker ps -q -a); }
drmi() { sudo docker rmi $(docker images -q); }
dirun() { sudo docker run -t -i --rm "$1" bash; }
dimrun() { sudo docker run --net=host -ti --volume="$1" "$2" bash; }
dbuild() { sudo docker build -t="$1" .; }
