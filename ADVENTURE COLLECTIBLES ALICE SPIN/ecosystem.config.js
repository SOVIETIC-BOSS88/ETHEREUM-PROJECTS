module.exports = {
    apps : [
        {
          name: "server",
          script: "/opt/alicetoken/web/server/server.js",
          watch: true,
          env: {
              "PORT": 3000,
              "NODE_ENV": "production",
              "INFURA_API_KEY": "{INFURA_API_KEY}",
              "CONTRACT_ADDRESS": "{CONTRACT_ADDRESS}",
              "AWS_ACCESS_KEY_ID": "{AWS_ACCESS_KEY_ID}",
              "AWS_SECRET_ACCESS_KEY": "{AWS_SECRET_ACCESS_KEY}"
          }
        }
    ]
  }