<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */
$routes->get('/', 'Home::index');
$routes->get('generator', 'Home::generator');
$routes->post('generator', 'Home::generator');
$routes->get('reader', 'Home::reader');
$routes->post('reader', 'Home::reader');