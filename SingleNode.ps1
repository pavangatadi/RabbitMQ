# run a standalone instance
docker network create rabbits

docker run -d --rm --net rabbits --hostname rabbit-manager --name rabbit-manager rabbitmq:3.8 

docker exec -it rabbit-manager cat /var/lib/rabbitmq/.erlang.cookie

docker rm -f rabbit-manager

docker run -d --rm --net rabbits -p 8080:15672 -e RABBITMQ_ERLANG_COOKIE=AGURGURZWERVREGCHTCE --hostname rabbit-manager --name rabbit-manager rabbitmq:3.8-management

docker exec -it rabbit-manager bash

rabbitmq-plugins enable rabbitmq_management

rabbitmq-plugins list

#join the manager

docker exec -it rabbit-manager rabbitmqctl stop_app
docker exec -it rabbit-manager rabbitmqctl reset
docker exec -it rabbit-manager rabbitmqctl join_cluster rabbit@rabbit-manager
docker exec -it rabbit-manager rabbitmqctl start_app
docker exec -it rabbit-manager rabbitmqctl cluster_status


cd messaging\rabbitmq\applications\publisher
docker build .\messaging\rabbitmq\applications\publisher -t aimvector/rabbitmq-publisher:v1.0.0
docker run -it --rm --net rabbits -e RABBIT_HOST=rabbit-manager -e RABBIT_PORT=5672 -e RABBIT_USERNAME=guest -e RABBIT_PASSWORD=guest -p 80:80 aimvector/rabbitmq-publisher:v1.0.0

cd messaging\rabbitmq\applications\consumer
docker build .\messaging\rabbitmq\applications\consumer -t aimvector/rabbitmq-consumer:v1.0.0
docker run -it --rm --net rabbits -e RABBIT_HOST=rabbit-manager -e RABBIT_PORT=5672 -e RABBIT_USERNAME=guest -e RABBIT_PASSWORD=guest aimvector/rabbitmq-consumer:v1.0.0

docker exec -it rabbit-manager rabbitmqctl cluster_status


docker run -d --rm --net rabbitmqaae1 --hostname rabbit-manager --name rabbit-manager rabbitmq:3.8-management 

docker exec -it rabbit-manager cat /var/lib/rabbitmq/.erlang.cookie

docker rm -f rabbit-manager

docker run -d --rm --net rabbits -p 8080:15672 -e RABBITMQ_ERLANG_COOKIE=AGURGURZWERVREGCHTCE --hostname rabbit-manager --name rabbit-manager rabbitmq:3.8-management
