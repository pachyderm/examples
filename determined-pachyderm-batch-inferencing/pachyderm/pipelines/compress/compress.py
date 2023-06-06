import os
import tarfile

def get_dir_files(dir):
    dir_files = []

    for root, _, files in os.walk(dir):
      for file in files:
        dir_files.append((os.path.join(root, file), file))

    return dir_files

train_files = get_dir_files('/pfs/train')
test_files = get_dir_files('/pfs/test')

with tarfile.open('/pfs/out/compressed.tar.gz', 'w:gz') as tf:
  for path, filename in train_files:
      tf.add(path, f'train/{filename}')
  for path, filename in test_files:
      tf.add(path, f'test/{filename}')
tf.close()
