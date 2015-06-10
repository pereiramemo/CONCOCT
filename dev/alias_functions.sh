drm() { docker rm $(docker ps -q -a); }
drmi() { docker rmi $(docker images -q); }
alias drun="docker run -t -i --rm"
dbuild() { docker build -t="$1" .; }
