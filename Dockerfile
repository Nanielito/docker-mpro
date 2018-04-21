FROM node:carbon

ENV COMMAND start
ENV DB_HOST 127.0.0.1

ARG VERSION

# Create app directories
RUN mkdir -p /home/mpro
WORKDIR /home/mpro

# Install app dependencies
COPY mpro/package*.json /home/mpro/

RUN npm install
# If you are building your code for production
# RUN npm install --only=production

# Copy app sources
COPY mpro/ /home/mpro/

# Build app
RUN npm run build

# Remove app sources
RUN rm -rf config docker scripts src .gitignore .jshintignore .jshintrc package*.json README.md 

# Move build app sources
RUN mv build/$VERSION/* /home/mpro/

# Remove empty build/$VERSION directory
RUN rm -rf build/$VERSION

# Copy entrypoint script
COPY init.sh /home/mpro

EXPOSE 3000

CMD ./init.sh
