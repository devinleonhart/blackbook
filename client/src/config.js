let envrionment = process.env.NODE_ENV;
const root = envrionment === 'production' ? 'https://blackbook.lionheart.design/' : 'http://localhost:3000/'
export const ENVIRONMENT = envrionment;
export const API_ROOT = root + 'api/v1/';
