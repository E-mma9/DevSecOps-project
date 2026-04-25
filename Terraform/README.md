# Terraform — DevSecOps Project

Deze map bevat alle Terraform code om de AWS infrastructuur op te zetten voor het DevSecOps project. De infrastructuur bestaat uit een VPC, EKS cluster, IAM rollen, een security group en een ECR repository.

---

## Mapstructuur

```
Terraform/
├── provider.tf          # AWS provider en S3 backend configuratie
├── main.tf              # Hoofdbestand dat alle modules aanroept
├── bootstrap/           # Eenmalige setup voor de Terraform state opslag
│   └── main.tf
└── modules/
    ├── VPC/             # Netwerk (VPC, subnets, NAT gateway, route tables)
    ├── IAM/             # IAM rollen en policies voor EKS
    ├── EKS/             # EKS cluster en node group
    └── SecurityGroup/   # Security group voor het cluster
```

---

## Hoe te gebruiken

### Stap 1 — Bootstrap (eenmalig)

De bootstrap map maakt de S3 bucket en DynamoDB tabel aan die Terraform gebruikt om de state op te slaan. Dit hoef je maar één keer uit te voeren.

```bash
cd bootstrap
terraform init
terraform apply
```

Dit maakt aan:
- Een S3 bucket (`devsecops-tfstate-<account-id>`) met versioning en encryptie
- Tegenwoordig is het niet meer nodig dat er een dynamodb voor locking word gebruikt omdat binnen s3 bucket de functie locking is gemaakt. (thx hashicorp)
### Stap 2 — Infrastructuur deployen

```bash
cd ..
terraform init
terraform plan
terraform apply
```

### Infrastructuur verwijderen

```bash
terraform destroy
```

> **Let op:** De S3 bucket heeft `prevent_destroy = true`. Verwijder deze handmatig via de AWS console als dat nodig is.

---

## provider.tf

Configureert de AWS provider en de remote backend.

```hcl
provider "aws" {
  region = "us-east-1"
}
```

De **backend** bepaalt waar de Terraform state wordt opgeslagen. Zonder remote backend slaat Terraform de state lokaal op als `terraform.tfstate`, wat niet handig is voor teamwerk.

```hcl
backend "s3" {
  bucket       = "devsecops-tfstate-450050505346"
  key          = "devsecops/terraform.tfstate"
  region       = "us-east-1"
  use_lockfile = true
  encrypt      = true
}
```

| Instelling | Uitleg |
|---|---|
| `bucket` | De S3 bucket waar de state file in wordt opgeslagen |
| `key` | Het pad binnen de bucket |
| `use_lockfile` | Voorkomt dat twee personen tegelijk `terraform apply` uitvoeren |
| `encrypt` | Versleutelt de state file — belangrijk omdat state gevoelige data kan bevatten |

---

## main.tf

Het hoofdbestand roept alle modules aan en geeft ze de juiste waarden mee. Resources praten hier niet rechtstreeks met elkaar — ze doen dat via module outputs zoals `module.VPC.vpc_id`.

---

## Module: VPC

**Locatie:** `modules/VPC/`

Zet het volledige netwerk op. Alle andere resources draaien binnen deze VPC.

### Wat er wordt aangemaakt

```
VPC (10.0.0.0/16)
├── public subnet 1  (10.0.3.0/24) — us-east-1a
├── public subnet 2  (10.0.4.0/24) — us-east-1b
├── private subnet 1 (10.0.1.0/24) — us-east-1a
├── private subnet 2 (10.0.2.0/24) — us-east-1b
├── Internet Gateway
├── NAT Gateway (in public subnet 1)
├── Public route table  → Internet Gateway
└── Private route table → NAT Gateway
```

### twee availability zones

EKS vereist subnets in minimaal twee verschillende AZs. Als één AZ uitvalt, kunnen de worker nodes in de andere AZ gewoon doorgaan.

### NAT Gateway

Worker nodes draaien in **private subnets** — ze hebben geen publiek IP adres. Ze hebben echter wel internettoegang nodig om container images te pullen vanuit ECR of Docker Hub. De NAT Gateway vertaalt hun verzoeken naar buiten zonder ze direct bereikbaar te maken vanaf het internet.



### Variabelen

| Variabele | Waarde | Uitleg |
|---|---|---|
| `vpc_cidr` | `10.0.0.0/16` | Het IP-bereik van de gehele VPC |
| `private_subnet_cidr` | `["10.0.1.0/24", "10.0.2.0/24"]` | IP-bereiken voor de private subnets |
| `public_subnet_cidr` | `["10.0.3.0/24", "10.0.4.0/24"]` | IP-bereiken voor de public subnets |
| `subnet_az` | `us-east-1a` | Eerste availability zone |
| `subnet_az2` | `us-east-1b` | Tweede availability zone |



## Module: IAM

**Locatie:** `modules/IAM/`

Maakt de IAM rollen aan die EKS nodig heeft om te functioneren. EKS mag zelf geen acties uitvoeren in AWS — daarvoor heeft het rollen nodig.

### Wat er wordt aangemaakt

**EKS Cluster rol** — voor de control plane

```
eks.amazonaws.com mag sts:AssumeRole
  └── AmazonEKSClusterPolicy (beheer van netwerken, nodes, lifecycle)
```

**EKS Node rol** — voor de worker nodes

```
ec2.amazonaws.com mag sts:AssumeRole
  ├── AmazonEKSWorkerNodePolicy     (nodes mogen zich aanmelden bij het cluster)
  ├── AmazonEKS_CNI_Policy          (netwerkconfiguratie voor pods)
  └── AmazonEC2ContainerRegistryReadOnly (images pullen vanuit ECR)
```
Doordat ik de AWS Learner Lab gebruik heb ik helaas niet de rechten om IAM rollen aan te maken en zal ik alleen de al gemaakte IAM role *LabRole* kunnen gebruiken. 
Op de werkvloer zou dit een grote security issue, maar nu kan ik niet anders. 
### Outputs

| Output | Uitleg |
|---|---|
| `cluster_name` | Naam van het cluster, doorgegeven aan de EKS module |
| `cluster_role_arn` | ARN van de control plane rol |
| `node_role_arn` | ARN van de worker node rol |

---

## Module: SecurityGroup

**Locatie:** `modules/SecurityGroup/`

Bepaalt welk netwerkverkeer is toegestaan voor het EKS cluster.

### Regels

| Richting | Protocol | Poort | Bron | Reden |
|---|---|---|---|---|
| Inkomend | Alle | Alle | Zichzelf | Node-to-node communicatie |
| Inkomend | TCP | 443 | VPC CIDR | Communicatie met de EKS API server |
| Uitgaand | Alle | Alle | `0.0.0.0/0` | Images pullen, AWS API calls |

### Outputs

| Output | Uitleg |
|---|---|
| `sg_id` | Doorgegeven aan de EKS module zodat het cluster de security group gebruikt |

---

## Module: EKS

**Locatie:** `modules/EKS/`

Maakt het Kubernetes cluster aan op AWS (EKS).

### Wat er wordt aangemaakt

**EKS Cluster** — de control plane (beheerd door AWS)
- Draait de Kubernetes API server, scheduler en controller manager
- AWS beheert deze volledig, je betaalt per uur dat het cluster actief is

**EKS Node Group** — de worker nodes (EC2 instances)
- Hier draaien de pods
- Nodes zitten alleen in **private subnets**
- Schaalt automatisch tussen `min_size` en `max_size`

### Variabelen

| Variabele | Waarde | Uitleg |
|---|---|---|
| `kubernetes_version` | `1.29` | Kubernetes versie — gebruik altijd een ondersteunde versie |
| `instance_type` | `t3.medium` | EC2 type voor de worker nodes |
| `desired_size` | `2` | Normaal gewenst aantal nodes |
| `min_size` | `1` | Minimum bij downscaling |
| `max_size` | `3` | Maximum bij upscaling |

### Outputs

| Output | Uitleg |
|---|---|
| `cluster_name` | Naam van het cluster |
| `cluster_endpoint` | URL van de Kubernetes API server — nodig voor `kubectl` |
| `cluster_ca_certificate` | Certificaat voor authenticatie met het cluster |

---

## Bootstrap

**Locatie:** `bootstrap/`

Aparte Terraform configuratie die je **eenmalig** uitvoert vóór de rest. Maakt de infrastructuur aan om de Terraform state veilig op te slaan.

### Wat er wordt aangemaakt

**S3 Bucket** 
- Versioning aan — je kunt terugrollen naar een vorige state
- AES-256 encryptie — de state file kan wachtwoorden en keys bevatten
- Publieke toegang geblokkeerd — alleen AWS accounts met de juiste rechten mogen erbij
- `prevent_destroy = true` — Terraform weigert de bucket te verwijderen


---

