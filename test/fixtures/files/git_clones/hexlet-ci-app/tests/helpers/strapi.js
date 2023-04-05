const Strapi = require('@strapi/strapi');
const fs = require('fs');

let instance;

async function setupStrapi() {
  if (!instance) {
    await Strapi().load();
    instance = strapi; // eslint-disable-line

    await instance.server.mount();
  }
  return instance;
}

async function cleanupStrapi() {
  const dbSettings = strapi.config.get('database.connections.default.settings'); // eslint-disable-line

  // close server to release the db-file
  await strapi.server.httpServer.close(); // eslint-disable-line

  // delete test database after all tests have completed
  if (dbSettings && dbSettings.filename) {
    const tmpDbFile = `${__dirname}/../${dbSettings.filename}`;
    if (fs.existsSync(tmpDbFile)) {
      fs.unlinkSync(tmpDbFile);
    }
  }
  // close the connection to the database
  await strapi.db.connection.destroy(); // eslint-disable-line
}

module.exports = { setupStrapi, cleanupStrapi };
