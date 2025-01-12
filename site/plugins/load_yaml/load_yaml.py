import os
import yaml
import logging
from pelican import signals

# Configure logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
handler = logging.StreamHandler()
handler.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
logger.addHandler(handler)

def load_yaml(generator):
    data_dir = os.path.join(generator.settings['PATH'], 'data')
    yaml_data = { }

    logger.debug(f"Loading YAML files from directory: {data_dir}")

    for root, _, files in os.walk(data_dir):
        relative_dir = os.path.relpath(root, data_dir)
        if relative_dir == '.':
            continue

        key = relative_dir.replace(os.path.sep, '_')  # Use directory as the key
        yaml_data[key] = { }  # Initialize as a list

        logger.debug(f"Processing directory: {relative_dir}")

        for filename in files:
            if filename.endswith('.yaml') or filename.endswith('.yml'):
                file_path = os.path.join(root, filename)
                logger.debug(f"Loading file: {file_path}")
                with open(file_path, 'r') as yaml_file:
                    item_data = yaml.safe_load(yaml_file)

                    file = os.path.splitext(filename)[0]
                    logger.debug(f"Loaded data: {file}")

                    yaml_data[key][file] = item_data
                    
                    logger.debug(f"Loaded data: {yaml_data}")

    # Store YAML_DATA in settings to make it accessible in content
    generator.settings['YAML_DATA'] = yaml_data
    generator.settings['ERICA'] = "Erica"

def add_settings_to_generator(generator, metadata):
    # Add specific settings to the global Jinja2 context
    generator.context['yaml_data'] = generator.settings.get('YAML_DATA', {})
    generator.context['site_name'] = generator.settings.get('SITENAME', 'My Pelican Site')
    metadata['ERICA'] = generator.settings.get('ERICA', 'Erica')


def register():
    signals.initialized.connect(load_yaml)
    signals.page_generator_context.connect(add_settings_to_generator)
