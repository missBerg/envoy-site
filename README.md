# Envoy Site Repository

Deploys on Netlify

---
# Run on Local

## Jekyll

Install Jekyll: https://jekyllrb.com/docs/installation/ 
This project uses Ruby version `3.3.5`

### Build
```
bundle exec jekyll build
```

### Serve
```
bundle exec jekyll serve
```

## Docker
Use docker compose to build and then run with watch.
**Run from the `local` directory.**

### Build
```
docker compose build
```

### Run
```
docker compose up --watch --remove-orphans
```

### Stop
```
docker compose down
```
