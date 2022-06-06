# building React app
FROM node:13 as build

WORKDIR /root

RUN git clone https://github.com/hysds/hysds_ui.git

COPY ../index.remote.template.js ../tosca.js ../figaro.js /root/hysds_ui/src/config/

RUN cd hysds_ui && \
  npm install --silent && \
  npm run build

# Creating the web server
FROM nginx:1.13.12-alpine

COPY --from=build /root/hysds_ui/dist /usr/share/nginx/html
COPY --from=build /root/hysds_ui/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
