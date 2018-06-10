'use strict';

// Node.js modules
var fs = require('fs'),
    path = require('path');

// NPM modules
var express = require('express'),
    // handlebars view engine for Express
    expHandlebars = require('express-handlebars'),
    // http request logger middleware for node.js
    logger = require('morgan'),
    // body parsing middleware
    bodyParser = require('body-parser'),
    // parse cookie header and populate req.cookies
    cookieParser = require('cookie-parser');

var app = express(),
    port = process.env.APP_PORT || 3000;

// config
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

// views
app.engine('handlebars', expHandlebars({
    defaultLayout: 'main',
    layoutsDir: path.join(__dirname, 'app/layouts')
}));
app.set('views', path.join(__dirname, 'app/views'));
app.set('view engine', 'handlebars');

// routes
app.use(require('./app/controllers/index'));

// catch 404 and forward to error handler
app.use(function(req, res, next) {
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
});

// error handler
app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.render('error', {
        message: err.message,
        error: (app.get('env') === 'development') ? err : {}
    });
});

app.listen(port);
if (app.get('env') === 'development') {
    console.log('Express app started on port: ' + port);
}

module.exports = app;
