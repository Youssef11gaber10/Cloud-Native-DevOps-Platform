require('dotenv').config();
const app = require('./app');
const sequelize = require('./config/db');
require('./modules/auth/auth.model');
require('./modules/projects/projects.model');
require('./modules/github/github.model');
require('./modules/ci/ci.model');
require('./modules/infra/network/network.model');
require('./modules/infra/ecr/ecr.model');
require('./modules/infra/vm/vm.model');

const PORT = process.env.PORT || 5000;

async function start() {
  try {
    await sequelize.authenticate();
    console.log('✅ Connected to MySQL');

    // await sequelize.sync({ alter: true });
    await sequelize.sync();
    console.log('✅ Users table synced');

    app.listen(PORT,  '0.0.0.0' , () => { // make app listion on 0.0.0.0 all interfaces on machine not only localhost
      console.log(`🚀 Server running on 0.0.0.0:${PORT} included cni insterface & docker interface `);
    });
  } catch (err) {
    console.error('❌ Failed to start:', err);
  }
}

start();