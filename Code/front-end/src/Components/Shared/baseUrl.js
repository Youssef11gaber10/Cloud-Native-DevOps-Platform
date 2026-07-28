const apiHost = process.env.REACT_APP_API_HOST || 'http://localhost';
const apiPort = process.env.REACT_APP_API_PORT || '5000';

const baseUrl = `${apiHost}:${apiPort}`;

export { baseUrl };