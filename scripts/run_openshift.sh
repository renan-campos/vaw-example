# Creates and runs the https server as a service in minikube.
# And a validation webhook that forbids secrets.

read -p "Enter repository to push image to: " image_repo
read -p "Enter namespace to deploy in: " namespace

source $(dirname $0)/keys.sh

image="vaw-example"
tag=$(date +%a-%H-%M-%S)
pod="vaw-example"

eval $(minikube docker-env)

docker build -t $image_repo/$image:$tag .
docker push $image_repo/$image:$tag

sed "s|IMAGE_NAME|$image_repo/$image:$tag|" yamls/deployment.yaml.template | \
sed "s|NAMESPACE|$namespace|" > yamls/deployment.yaml

ENCODED_CA=$(base64 -w 0 $CA_PUBLIC)
sed "s|CA_BUNDLE|$ENCODED_CA|" yamls/webhook.yaml.template | \
sed "s|NAMESPACE|$namespace|" > yamls/webhook.yaml

sed "s|NAMESPACE|$namespace|" yamls/service.yaml.template > yamls/service.yaml

sed "s|NAMESPACE|$namespace|" yamls/sa.yaml.template > yamls/sa.yaml

oc apply -f yamls/sa.yaml
oc apply -f yamls/deployment.yaml
oc apply -f yamls/service.yaml
oc apply -f yamls/webhook.yaml

echo "Trying to create a secret after deploying validation webhook..."
sleep 1
sed "s|NAMESPACE|$namespace|" yamls/secret.yaml.template > yamls/secret.yaml
oc apply -f yamls/secret.yaml
