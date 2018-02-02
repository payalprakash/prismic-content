
/**
 * Module dependencies.
 */
const express = require('express');
const favicon = require('serve-favicon');
const logger = require('morgan');
const bodyParser = require('body-parser');
const methodOverride = require('method-override');
const errorHandler = require('errorhandler');
const path = require('path');
const ejs = require('ejs');

module.exports = (() => {
  const app = express();

  // all environments
  app.set('port', process.env.PORT || 3000);
  app.set('views', path.join(__dirname, 'views'));
  app.engine('html', require('ejs').renderFile);
  app.set('view engine', 'html');
  app.use(favicon('public/images/punch.png'));
  app.use(logger('dev'));
  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded({ extended: false }));
  app.use(methodOverride());
  app.use(express.static(path.join(__dirname, 'public')));

  app.use(errorHandler());

  return app;
})();
