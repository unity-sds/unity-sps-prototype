# building React app
FROM node:13 as build

WORKDIR /root

RUN git clone https://github.com/unity-sds/hysds_ui_with_auth.git

COPY index.remote.auth.template.js /root/hysds_ui_with_auth/src/config/index.js
COPY tosca.js figaro.js /root/hysds_ui_with_auth/src/config/

RUN cd hysds_ui_with_auth && \
  npm install --silent && \
  npm run build

# Creating the web server
FROM nginx:1.13.12-alpine

COPY --from=build /root/hysds_ui_with_auth/dist /usr/share/nginx/html
COPY --from=build /root/hysds_ui_with_auth/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
