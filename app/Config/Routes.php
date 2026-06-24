<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */
$routes->get('/', 'Home::index');
$routes->get('testing', 'Home::testing');
$routes->post('generator', 'Home::generator');
$routes->post('reader', 'Home::reader');