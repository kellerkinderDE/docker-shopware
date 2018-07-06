<?php

$basePath = '/var/www/html/custom/plugins';

class KellerkinderPlugin
{
    public static function setupPlugin($configurationFile, $targetPath)
    {
        if(!file_exists($configurationFile)) {
            die("File is missing");
        }

        $configuration = json_decode(file_get_contents($configurationFile), true);
        if(!is_array($configuration)) {
            die("File is malformed");
        }

        foreach($configuration['dependencies'] as $dependency) {
            if($dependency['zip_url']) {
                $file = file_get_contents($dependency['zip_url']);
                file_put_contents('/tmp/dependency.zip', $file);

                $zip = new ZipArchive;
                $res = $zip->open('/tmp/dependency.zip');
                if ($res === true) {
                    $zip->extractTo($targetPath);
                    $zip->close();
                } else {
                    unlink('/tmp/dependency.zip');
                    die(sprintf('Dependency %s was not a valid ZIP file', $dependency['name']));
                }

                unlink('/tmp/dependency.zip');
            } elseif($dependency['clone_url']) {
                shell_exec(sprintf('git clone --depth=1 %s %s/%s', $dependency['clone_url'], $targetPath, $dependency['name']));
            }

            $newConfiguration = sprintf('%s/%s/kellerkinder-plugin.json', $targetPath, $dependency['name']);
            if(file_exists($newConfiguration)) {
                self::setupPlugin($newConfiguration, $targetPath);
            }
        }
    }
}

KellerkinderPlugin::setupPlugin($argv[1], $basePath);
