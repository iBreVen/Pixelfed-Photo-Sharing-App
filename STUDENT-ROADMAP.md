# STUDENT ROADMAP - PixelFed Docker Installation Project

## Project Description

You will install **PixelFed** (an Instagram-like open source social media platform) using Docker on AWS cloud platform.

**Goal:** PixelFed instance running at `http://SERVER-IP:8080`

**Deliverables:** Screenshots + report

---

## Requirements

- AWS account (student account is sufficient)
- Basic Linux knowledge
- Understanding of Docker concepts
- Ability to use SSH

---

## Steps Summary (10 Steps)

1. Create AWS EC2 instance
2. Connect via SSH
3. System update
4. Install Docker
5. Clone repository
6. Edit .env file
7. Start containers
8. Run setup script
9. Create admin user
10. Web test

---

## Step 1: Create AWS EC2 Instance

### What Will You Do?

You will rent a Linux server on Amazon Web Services.


### How?

**AWS Console → EC2 → Launch Instance**

**To Do:**
- Name: `pixelfed-server`
- AMI: Amazon Linux 2023
- Instance type: t2.medium (2 vCPU, 4 GB RAM)
- Create and download key pair (.pem file)
- Security Group: Open ports 22 (SSH) and 8080 (PixelFed)


## Step 2: SSH Connection

### What Will You Do?

You will connect to the server via terminal.

### Why?

You need terminal access to send commands to the server. There's no GUI, everything is command-line.


## Step 3: System Update

### What Will You Do?

You will update packages on the server.

### Why?

For security patches and latest packages. Old packages can cause errors.

### How?

- Update system with yum update
- Install required tools like curl and git


## Step 4: Docker Installation

### What Will You Do?

You will install Docker and Docker Compose.

### Why?

PixelFed consists of multiple services (web, database, redis, worker). With Docker, you run all of them as isolated containers.


### What is Docker Compose?

A tool that manages multiple containers with a single command. Our project has 4+ containers.

### How?

- Install Docker with yum
- Start and enable Docker service
- Add user to docker group
- Download Docker Compose binary from GitHub


## Step 5: Clone Repository

### What Will You Do?

You will clone the GitHub repository prepared by your instructor.

### Why?

PixelFed installation files, docker-compose.yaml, and .env.production template are ready in this repo. **Also includes automatic setup script!**

### Repository Address

```
https://github.com/---------------
```

### How?

- Run git clone in home directory
- Enter pixelfed folder
- Check files

### Should See

- compose.yaml (Docker services definition)
- .env.production (environment template)
- **setup-pixelfed.sh** ← AUTOMATIC SETUP SCRIPT!
- KURULUM.md (detailed installation guide)

## Step 6: Edit .env File

### What Will You Do?

You will edit environment variables.

### Why?

You need to tell PixelFed your server IP, database password, etc. Each installation uses different settings.

### 4 Fields to Edit

**1. APP_NAME** (Line 2)
- Application name
- Example: "PixelFed"

**2. APP_DOMAIN** (Line 3)
- **ONLY** server IP (NO PORT!)
- Example: "54.221.128.45"
- **Where to find:** AWS Console → EC2 → Public IPv4
- **⚠️ CRITICAL:** Don't add `:8080`! Port only in APP_URL
- **Note:** APP_URL is automatically generated from APP_DOMAIN

**3. INSTANCE_CONTACT_EMAIL** (Line 6)
- Contact email
- Example: "admin@pixelfed.local"

**4. DB_PASSWORD** (Line 7)
- Database password
- **Set a strong password!**
- Example: "PixelFed2025_Secure!"

### How to Edit?

- Copy .env.production to .env
- Open with nano or vim
- Search with Ctrl+W and change
- Save with Ctrl+O



## Step 7: Start Containers

### What Will You Do?

You will start all services with Docker Compose.

### Why?

PixelFed isn't a single application, it's an orchestration of multiple services:
- **web:** Apache + PHP
- **worker:** Background jobs
- **db:** MariaDB database
- **redis:** Cache

### How?

- Start with docker-compose up -d command
- -d: detached mode (run in background)
- Wait 2-3 minutes (first startup is long)

### Status Check

Check with docker-compose ps.

**Should see:**
- pixelfed-web: Up
- pixelfed-worker: Up
- pixelfed-db: Up
- pixelfed-redis: Up


## Step 8: Automated Setup Script ⚡

### What Will You Do?

You will run the ready-made setup script.



### How to Run?

**Method 1: With Script (Easy)**
```bash
chmod +x setup-pixelfed.sh
./setup-pixelfed.sh
```

## Step 9: Create Admin User

### What Will You Do?

You will create the first user (admin).

### Why?

You need a user to log into PixelFed. The first user will be admin.

### How?

Single command:
```bash
sudo docker-compose exec web php artisan user:create
```

### What to Enter

The script will ask you in sequence:
```
Username: admin
Email: admin@pixelfed.local
Name: Admin User
Password: (strong password - invisible)
Confirm Password: (same password)
Make this user an admin? (yes/no): yes
Confirm user creation? (yes/no): yes
```

### Success Criteria

- [ ] User created
- [ ] "Created new user!" message appeared
- [ ] Admin privileges granted
- [ ] Password saved (don't forget!)

