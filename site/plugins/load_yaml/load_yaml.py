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

def recursive_dict():
    """Helper function to create a nested defaultdict-like structure."""
    from collections import defaultdict
    return defaultdict(recursive_dict)

def load_yaml(generator):
    data_dir = os.path.join(generator.settings['PATH'], 'data')
    yaml_data = recursive_dict()

    logger.debug(f"Loading YAML files from directory: {data_dir}")

    for root, _, files in os.walk(data_dir):
        relative_dir = os.path.relpath(root, data_dir)
        if relative_dir == '.':
            # Skip the root data directory
            continue

        # Break relative_dir into components for nested dictionary structure
        dir_parts = relative_dir.split(os.sep)
        current_level = yaml_data

        # Traverse or create the nested structure based on directories
        for part in dir_parts:
            current_level = current_level[part]

        logger.debug(f"Processing directory: {relative_dir}")

        for filename in files:
            if filename.endswith('.yaml') or filename.endswith('.yml'):
                file_path = os.path.join(root, filename)
                logger.debug(f"Loading file: {file_path}")
                with open(file_path, 'r') as yaml_file:
                    item_data = yaml.safe_load(yaml_file)

                    file_key = os.path.splitext(filename)[0]
                    current_level[file_key] = item_data

                    logger.debug(f"Loaded data for {file_key} into {relative_dir}: {item_data}")

    # Convert defaultdict to a standard dictionary before storing
    generator.settings['YAML_DATA'] = dict(yaml_data)

def add_settings_to_generator(generator, metadata):
    # Add specific settings to the global Jinja2 context
    generator.context['yaml_data'] = generator.settings.get('YAML_DATA', {})

def register():
    signals.initialized.connect(load_yaml)
    signals.page_generator_context.connect(add_settings_to_generator)
