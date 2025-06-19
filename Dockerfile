FROM node:22.16.0-alpine AS builder
RUN addgroup -S newgroup && adduser -S newuser -G newgroup
WORKDIR /usr/src/app
RUN chown newuser:newgroup /usr/src/app
USER newuser
COPY --chown=newuser:newgroup package*.json ./
RUN npm install
COPY --chown=newuser:newgroup . .
RUN npm run build
RUN npm prune --production
 
FROM gcr.io/distroless/nodejs22-debian12
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
USER newuser
EXPOSE 3000
CMD ["dist/main"]