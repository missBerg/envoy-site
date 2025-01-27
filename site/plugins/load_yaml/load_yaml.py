import os
import yaml
import logging
from pathlib import Path
from collections import defaultdict
from pelican import signals

# Configure logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
handler = logging.StreamHandler()
handler.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
logger.addHandler(handler)

def recursive_dict():
    """Create a nested defaultdict-like structure."""
    return defaultdict(recursive_dict)

def is_yaml_file(filename: str) -> bool:
    """Check if a file is a YAML file based on extension."""
    return filename.endswith(('.yaml', '.yml'))

def load_yaml_file(file_path: Path) -> tuple[bool, dict | list | None]:
    """Load and validate a single YAML file.
    
    Returns:
        tuple: (success, data)
            - success: bool indicating if load was successful
            - data: the loaded YAML data if successful, None otherwise
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as yaml_file:
            data = yaml.safe_load(yaml_file)
            
            if data is None:
                logger.warning(f"Empty YAML file: {file_path}")
                return False, None
                
            if not isinstance(data, (dict, list)):
                logger.warning(f"Invalid YAML content in {file_path}. Expected dict or list, got {type(data)}")
                return False, None
                
            return True, data
            
    except yaml.YAMLError as e:
        logger.error(f"Failed to parse YAML file {file_path}: {str(e)}")
        return False, None
    except Exception as e:
        logger.error(f"Error processing file {file_path}: {str(e)}")
        return False, None

def process_directory(root: Path, data_dir: Path, yaml_data: dict) -> None:
    """Process a single directory and load its YAML files into the data structure."""
    relative_dir = os.path.relpath(root, data_dir)
    if relative_dir == '.':
        return  # Skip root directory
        
    # Navigate to the correct nested dictionary level
    current_level = yaml_data
    for part in relative_dir.split(os.sep):
        current_level = current_level[part]
    
    logger.debug(f"Processing directory: {relative_dir}")
    
    # Process each YAML file in the directory
    for filename in os.listdir(root):
        if not is_yaml_file(filename):
            continue
            
        file_path = root / filename
        success, data = load_yaml_file(file_path)
        
        if success:
            file_key = Path(filename).stem  # Get filename without extension
            current_level[file_key] = data
            logger.debug(f"Loaded data for {file_key} into {relative_dir}")

def load_yaml(generator):
    """Load YAML files from the data directory into the generator settings.
    
    Safely handles missing directories and invalid YAML files.
    """
    try:
        data_dir = Path(generator.settings['PATH']) / 'data'
        
        if not data_dir.exists():
            logger.warning(f"Data directory not found: {data_dir}")
            generator.settings['YAML_DATA'] = {}
            return
            
        yaml_data = recursive_dict()
        logger.debug(f"Loading YAML files from directory: {data_dir}")

        # Process each directory
        for root, _, _ in os.walk(data_dir):
            try:
                process_directory(Path(root), data_dir, yaml_data)
            except Exception as e:
                logger.error(f"Error processing directory {root}: {str(e)}")

        # Convert defaultdict to regular dict before storing
        generator.settings['YAML_DATA'] = dict(yaml_data)
        
    except Exception as e:
        logger.error(f"Failed to load YAML data: {str(e)}")
        generator.settings['YAML_DATA'] = {}

def add_yaml_to_context(generator, metadata):
    """Add YAML data to the global Jinja2 context."""
    generator.context['yaml_data'] = generator.settings.get('YAML_DATA', {})

def register():
    """Register the plugin with Pelican."""
    signals.initialized.connect(load_yaml)
    signals.page_generator_context.connect(add_yaml_to_context)
