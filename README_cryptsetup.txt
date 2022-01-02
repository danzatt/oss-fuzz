sudo python infra/helper.py build_image cryptsetup
sudo python infra/helper.py build_fuzzers cryptsetup

# On selinux systems:
sudo chcon -Rt svirt_sandbox_file_t build/

# Run LUKS2 fuzzer
sudo python infra/helper.py run_fuzzer --corpus-dir build/corpus/cryptsetup/crypt2_load_fuzz/ --sanitizer address cryptsetup crypt2_load_fuzz -jobs=8 -workers=8

# Rebuild fuzz targets for coverage
sudo python infra/helper.py build_fuzzers --sanitizer coverage cryptsetup

# Generate coverage report
sudo python infra/helper.py coverage cryptsetup --no-corpus-download --fuzz-target crypt2_load_fuzz
