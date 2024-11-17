# Monitoramento de Conectividade de Nós

Este script monitora a conectividade dos nós em AWS e GCP, realizando pings a cada 60 segundos e enviando alertas por e-mail quando um nó está inacessível. O script utiliza o `ping` para verificar a conectividade e o `msmtp` para enviar os e-mails.

## Requisitos

### 1. **Instalar Dependências**

Você precisa instalar algumas ferramentas para que o script funcione corretamente:

- **msmtp**: Usado para enviar e-mails a partir do terminal.
- **aws-cli**: Usado para consultar instâncias na AWS.
- **gcloud-cli**: Usado para consultar instâncias no Google Cloud Platform (GCP).

#### Para instalar as dependências:

- **msmtp**:
  - No Ubuntu/Debian: 
    ```bash
    sudo apt-get install msmtp msmtp-mta
    ```
  - No CentOS/RHEL:
    ```bash
    sudo yum install msmtp
    ```

- **aws-cli**:
  - Siga as instruções para instalação em [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

- **gcloud-cli**:
  - Siga as instruções de instalação em [Google Cloud SDK](https://cloud.google.com/sdk/docs/install).

### 2. **Configurar o `msmtp` para envio de e-mails**

1. Crie o arquivo de configuração do `msmtp`:
   ```bash
   touch ~/.msmtprc


2. Edite o arquivo ~/.msmtprc para configurar o servidor SMTP. Exemplo para configurar com o Gmail:

 ```bash
account default
host smtp.gmail.com
port 587
from YOUR_GMAIL_EMAIL
user YOUR_GMAIL_EMAIL
password YOUR_GMAIL_PASSWORD
tls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
 ```
Nota: Substitua YOUR_GMAIL_PASSWORD pela senha do seu Gmail ou por um App Password caso tenha a verificação em duas etapas habilitada.
Importante: Verifique se o Gmail está permitindo o acesso a aplicativos menos seguros. Ativar acesso a aplicativos menos seguros.

Defina permissões adequadas no arquivo de configuração:

 ```bash
chmod 600 ~/.msmtprc
 ```
3. Configurar AWS CLI
Configure suas credenciais AWS:

 ```bash
aws configure
 ```
Isso solicitará a chave de acesso, a chave secreta e a região. Essas credenciais são necessárias para que o script possa consultar as instâncias na AWS.

4. Configurar GCP CLI
Autentique-se no Google Cloud:

 ```bash
gcloud auth login
 ```
Selecione o projeto desejado:

 ```bash
gcloud config set project YOUR_PROJECT_ID
 ```
5. Rodar o Script
Faça o download ou crie o arquivo network_monitor.sh no seu sistema.

Dê permissão de execução para o script:

 ```bash
chmod +x network_monitor.sh
 ```
Execute o script:

 ```bash
./network_monitor.sh
 ```
O script começará a monitorar os nós da AWS e do GCP. Ele tentará enviar um e-mail para YOUR_GMAIL_EMAIL sempre que um nó ficar inacessível.

Estrutura do Script:

send_email(): Envia um e-mail para o endereço configurado, informando o status de um nó.

monitor_node(): Realiza o ping em um nó e, caso ele esteja inacessível, chama send_email() para notificar.

monitor_aws_nodes(): Monitora todos os nós da AWS.

monitor_gcp_nodes(): Monitora todos os nós do GCP.

get_aws_nodes(): Obtém os IPs públicos das instâncias EC2 na AWS usando aws-cli.

get_gcp_nodes(): Obtém os IPs externos das instâncias no Google Cloud usando gcloud-cli.

O script será executado em loop, verificando a conectividade de cada nó a cada 60 segundos.

Logs:
Todos os eventos de conectividade e envio de e-mail serão registrados no arquivo network_status.log.

Notas Adicionais:

Segurança de E-mail: Se você usar uma conta de e-mail que não seja do Gmail, será necessário ajustar as configurações do msmtp para o seu servidor SMTP.

Outras Nuvens: Para adicionar mais provedores de nuvem, você pode adaptar as funções get_aws_nodes e get_gcp_nodes para outros serviços, como Azure ou DigitalOcean.
