# Comprehensive Deployment Guide

## Prerequisites
- Node.js 16+
- Firebase CLI (`npm install -g firebase-tools`)
- Google Cloud SDK (`gcloud`)
- Docker (for containerized deployment)
- Flutter SDK (for mobile app)

## Environment Setup

### 1. Firebase Project Setup

```bash
# Login to Firebase
firebase login

# Create or select project
firebase use --add

# Initialize Firestore
firebase init firestore

# Deploy security rules and indexes
firebase deploy
```

### 2. Backend Deployment Options

#### Option A: Firebase Cloud Functions (Easiest)

```bash
cd backend

# Install Firebase functions
npm install -g firebase-tools

# Create functions directory
firebase init functions

# Deploy functions
firebase deploy --only functions

# View logs
firebase functions:log
```

#### Option B: Google Cloud Run (Recommended for Scale)

```bash
# Build image
docker build -t uno-game-backend ./backend

# Tag image
docker tag uno-game-backend gcr.io/PROJECT_ID/uno-game-backend:latest

# Push to Container Registry
docker push gcr.io/PROJECT_ID/uno-game-backend:latest

# Deploy to Cloud Run
gcloud run deploy uno-game-backend \
  --image gcr.io/PROJECT_ID/uno-game-backend:latest \
  --platform managed \
  --region us-central1 \
  --set-env-vars=\
NODE_ENV=production,\
FIREBASE_PROJECT_ID=PROJECT_ID,\
FIREBASE_PRIVATE_KEY="$(cat key.json | jq -r '.private_key')",\
FIREBASE_CLIENT_EMAIL=EMAIL

# View service details
gcloud run services describe uno-game-backend --region=us-central1
```

#### Option C: AWS Elastic Beanstalk

```bash
# Install AWS CLI and EB CLI
pip install awsebcli

# Initialize EB application
eb init -p "Node.js" uno-game-backend

# Create environment
eb create uno-game-backend

# Deploy
eb deploy

# Monitor
eb logs
```

#### Option D: Traditional VPS (DigitalOcean, Linode, etc.)

```bash
# SSH into server
ssh -i key.pem ubuntu@your-server.com

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Clone repository
git clone https://github.com/yourusername/uno-game.git
cd uno-game/backend

# Install dependencies
npm install --production

# Install PM2
sudo npm install -g pm2

# Start application
pm2 start src/index.ts --interpreter ts-node --name "uno-backend"

# Setup startup
pm2 startup
pm2 save

# Configure Nginx
sudo apt-get install -y nginx

# Copy Nginx config
sudo cp ../nginx.conf /etc/nginx/nginx.conf

# Start Nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Setup SSL with Let's Encrypt
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot certonly --nginx -d uno-game.com -d api.uno-game.com
```

### 3. Frontend Deployment

#### Google Play Store

```bash
# Create keystore
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Configure Android app signing
# Edit android/app/build.gradle:
# Add signing config
# Update buildTypes to use signingConfig

# Build APK
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/debug_symbols

# Upload to Google Play Console
# https://console.cloud.google.com/google-play-developer-console
```

#### Apple App Store

```bash
# Ensure Xcode is updated
xcode-select --install

# Build iOS app
flutter build ios --release

# Create app archive
open ios/Runner.xcworkspace

# Select appropriate team, configure signing
# Archive: Product → Archive
# Upload via Organizer in Xcode
```

#### Web Deployment (Optional)

```bash
# Build web version
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

## Database Configuration

### Firestore Security Rules

```bash
# Apply security rules
firebase deploy --only firestore:rules
```

### Create Collections and Indexes

```bash
# Run initialization script
cd backend
npm run db:init
```

## Monitoring and Maintenance

### Health Checks

```bash
# Test API health
curl https://api.uno-game.com/health

# Check WebSocket
curl -i -N -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  https://api.uno-game.com/socket.io
```

### View Logs

Firebase Functions:
```bash
firebase functions:log
```

Cloud Run:
```bash
gcloud run logs read uno-game-backend --region=us-central1 --limit 50
```

VPS:
```bash
pm2 logs uno-backend
tail -f /var/log/nginx/access.log
```

### Database Backups

```bash
# Export Firestore
gcloud firestore export gs://backup-bucket/$(date +%s)

# Set up automatic backups
gcloud beta firestore backups create \
  --location=us-central1 \
  --retention=7d
```

## Scaling Configuration

### For Horizontal Scaling

1. **Enable Cloud SQL Proxy** (if using SQL database)
```bash
gcloud compute instances create proxy \
  --image-family=debian-10 \
  --image-project=debian-cloud
```

2. **Setup Redis for caching**
```bash
# In docker-compose.yml or Cloud Memorystore
docker run -d -p 6379:6379 redis:7-alpine
```

3. **Configure Socket.io with Redis adapter**
```javascript
// backend/src/index.ts
import { createAdapter } from "@socket.io/redis-adapter";
import { createClient } from "redis";

const pubClient = createClient();
const subClient = pubClient.duplicate();

io.adapter(createAdapter(pubClient, subClient));
```

### Load Balancing

**Cloud Load Balancer:**
```bash
gcloud compute backend-services create uno-game-backend \
  --protocol=HTTP \
  --global

gcloud compute backend-services add-backends uno-game-backend \
  --instance-group=uno-game-instances \
  --instance-group-zone=us-central1-a \
  --global
```

## Performance Optimization

### 1. Enable CDN
```bash
# Setup Cloud CDN
gcloud compute backend-services update uno-game-backend \
  --enable-cdn \
  --cache-mode=CACHE_ALL_STATIC
```

### 2. Optimize Images
```bash
# Compress images before deployment
imagemin flutter_app/assets/images/** --out-dir=flutter_app/assets/images-optimized
```

### 3. Configure Caching Headers
```
# In nginx.conf or firebaseconfig.js
Cache-Control: public, max-age=31536000, immutable
```

## Security Checklist

- [ ] Change all default credentials
- [ ] Enable HTTPS/TLS (Let's Encrypt or custom certificate)
- [ ] Configure CORS properly
- [ ] Set strong JWT secret
- [ ] Enable Firebase authentication
- [ ] Configure Firestore security rules
- [ ] Enable rate limiting
- [ ] Setup DDoS protection
- [ ] Regular security updates
- [ ] Monitor for suspicious activity

## Troubleshooting Deployment

### Backend won't start
```bash
# Check environment variables
env | grep FIREBASE

# Check port availability
lsof -i :3000

# View detailed logs
npm run dev -- --debug
```

### Database connection issues
```bash
# Verify Firebase credentials
gcloud auth application-default print-access-token

# Test Firestore connection
npm test -- auth.test.ts
```

### WebSocket connection problems
```bash
# Check CORS configuration
curl -H "Origin: app-url" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: upgrade" \
  https://api.uno-game.com/socket.io
```

## Rollback Procedure

### From Cloud Run
```bash
# List previous revisions
gcloud run revisions list --service=uno-game-backend

# Rollback to previous version
gcloud run services update uno-game-backend \
  --to-revisions uno-game-backend-VERSION
```

### From VPS
```bash
# Revert to previous release
pm2 restart uno-backend --version=1.0.0
```

## Cost Estimation

### Firebase (estimated monthly)
- Firestore: $0.06 per 100K reads (500K free)
- Storage: $0.18 per GB
- Functions: $0.40 per 1M invocations

### Google Cloud
- Cloud Run: $0.00002400 per vCPU-second
- Cloud Load Balancer: $0.025 per hour
- Cloud SQL: $3.50 - $500+ per month

### AWS (alternative)
- Elastic Beanstalk: $0.025 - $10+ per hour
- RDS: $0.17 - $1000+/month
- DynamoDB: Pay-as-you-go pricing

## Post-Deployment

1. Update DNS records
2. Setup monitoring and alerts
3. Configure automated backups
4. Setup CI/CD pipeline
5. Monitor performance metrics
6. Plan maintenance windows
7. Document deployment process
8. Train team on runbooks

## Support & Resources

- Firebase Documentation: https://firebase.google.com/docs
- Node.js Best Practices: https://nodejs.org/en/docs/
- Google Cloud Documentation: https://cloud.google.com/docs
- Socket.io Documentation: https://socket.io/docs/
- Flutter Documentation: https://flutter.dev/docs
