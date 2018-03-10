FROM node:carbon

ENV COMMAND start
ENV DB_HOST 127.0.0.1

# Create app directory
RUN mkdir -p /home/mpro
WORKDIR /home/mpro

# Install app dependencies
COPY mpro/package*.json /home/mpro/

RUN npm install
# If you are building your code for production
# RUN npm install --only=production

# Bundle app source
COPY mpro/ /home/mpro/

COPY init.sh /home/mpro

EXPOSE 3000

CMD ./init.sh
