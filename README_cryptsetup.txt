sudo python infra/helper.py build_image cryptsetup
sudo python infra/helper.py build_fuzzers cryptsetup

# on selinux systems:
sudo chcon -Rt svirt_sandbox_file_t build/

sudo python infra/helper.py run_fuzzer cryptsetup crypt_load_fuzz
