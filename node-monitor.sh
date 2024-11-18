#!/bin/bash

LOG_FILE="network_status.log"
EMAIL_TO="YOUR_GMAIL_EMAIL"

send_email() {
    local node=$1
    local status=$2
    echo "Enviando e-mail sobre $node ($status)"
    echo -e "Subject: Alerta de Conectividade: $node\n\nO nó $node está $status em $(date)." | msmtp "$EMAIL_TO" && \
    echo "$(date): E-mail enviado sobre $node ($status)" >> "$LOG_FILE" || \
    echo "$(date): Erro ao enviar e-mail sobre $node ($status)" >> "$LOG_FILE"
}

check_node() {
    local node=$1
    if ping -c 1 -W 2 "$node" > /dev/null; then
        echo "$(date): $node está acessível" >> "$LOG_FILE"
    else
        echo "$(date): $node está inacessível" >> "$LOG_FILE"
        send_email "$node" "inacessível"
    fi
}

get_nodes() {
    local provider=$1
    case $provider in
        aws) aws ec2 describe-instances --query 'Reservations[].Instances[].PublicIpAddress' --output text ;;
        gcp) gcloud compute instances list --format="value(EXTERNAL_IP)" ;;
        *) echo "Provedor desconhecido: $provider" ;;
    esac
}

monitor_nodes() {
    local provider=$1
    local nodes=("$@")
    echo "Monitorando nós de $provider: ${nodes[*]}"
    for node in "${nodes[@]:1}"; do
        check_node "$node"
    done
}

# Fluxo principal do script
aws_nodes=($(get_nodes "aws"))
gcp_nodes=($(get_nodes "gcp"))

echo "Nós AWS: ${aws_nodes[*]}"
echo "Nós GCP: ${gcp_nodes[*]}"

while true; do
    monitor_nodes "AWS" "${aws_nodes[@]}"
    monitor_nodes "GCP" "${gcp_nodes[@]}"
    sleep 60
done
