#!/bin/bash

cd /var/www/html || exit
cat <<EOF | sudo tee /var/www/html/deploy.php
<?php
namespace Deployer;
require_once 'recipe/common.php';
set('repository', '${PATH}');
set('deploy_path', '/var/www/html');
set('default_timeout', 900);
set('theme_path', $THEME);
set('composer_options', 'install --verbose --prefer-dist --no-progress --no-interaction --no-dev');
// Configuration
set('shared_files', [
    'app/etc/env.php',
    'sitemap.xml'
]);
set('shared_dirs', [
    'var/log',
    'var/backups',
    'var/session',
    'var/report',
    'pub/media'
]);
set('writable_dirs', [
    'var',
    'pub/static',
    'pub/media'
]);
set('clear_paths', [
    'generated/*'
]);
set('npm', function () {
    return locateBinaryPath('npm');
});
// Tasks
desc('Enable all modules');
task('magento:enable', function () {
    run("{{bin/php}} {{release_path}}/bin/magento module:enable --all");
});
desc('Compile magento di');
task('magento:compile', function () {
    run("{{bin/php}} {{release_path}}/bin/magento setup:di:compile");
});
desc('Gulp task runner');
task('magento:gulp', function () {
    run("cd {{release_path}} && {{npm}} install && gulp");
});
desc('Gulp minify js');
task('magento:gulp:minify', function () {
    run("cd {{release_path}} && gulp minify");
});
desc('Gulp cleanup');
task('magento:gulp:cleanup', function () {
    run("cd {{release_path}} && rm -r {{release_path}}/node_modules");
});
desc('Deploy assets');
task('magento:deploy:assets', function () {
    run("{{bin/php}} {{release_path}}/bin/magento setup:static-content:deploy --theme {{theme_path}} en_GB en_US");
});
desc('Deploy backend assets');
task('magento:deploy:assets-backend', function () {
   run("{{bin/php}} {{release_path}}/bin/magento setup:static-content:deploy --area adminhtml en_GB en_US");
});
desc('Enable maintenance mode');
task('magento:maintenance:enable', function () {
    run("if [ -d \$(echo {{deploy_path}}/current) ]; then {{bin/php}} {{deploy_path}}/current/bin/magento maintenance:enable; fi");
});
desc('Disable maintenance mode');
task('magento:maintenance:disable', function () {
    run("if [ -d \$(echo {{deploy_path}}/current) ]; then {{bin/php}} {{deploy_path}}/current/bin/magento maintenance:disable; fi");
});
desc('Upgrade magento database');
task('magento:upgrade:db', function () {
    run("{{bin/php}} {{release_path}}/bin/magento setup:upgrade");
});
desc('Flush Magento Cache');
task('magento:cache:flush', function () {
    run("{{bin/php}} {{release_path}}/bin/magento cache:flush");
});
desc('Copy robots.txt File');
task('deploy:robots', function () {
    run("cp {{deploy_path}}/robots.txt {{release_path}}/robots.txt");
});
desc('Copy .htaccess File');
task('deploy:htaccess', function () {
    run("rm {{release_path}}/.htaccess && cp {{deploy_path}}/htaccess {{release_path}}/.htaccess");
});
desc('Magento2 deployment operations');
task('deploy:magento', [
    'magento:enable',
    'magento:maintenance:enable',
    'magento:upgrade:db',
    'magento:maintenance:disable',
    'magento:compile',
    'magento:deploy:assets',
    'magento:deploy:assets-backend'
]);
desc('Deploy your project');
task('deploy', [
    'deploy:info',
    'deploy:prepare',
    'deploy:lock',
    'deploy:release',
    'deploy:update_code',
    'deploy:shared',
    'deploy:writable',
    'deploy:vendors',
    'deploy:clear_paths',
    'deploy:magento',
    'deploy:htaccess',
    'deploy:robots',
    'deploy:symlink',
    'deploy:unlock',
    'cleanup',
    'success'
]);
after('deploy:failed', 'magento:maintenance:disable');
EOF

