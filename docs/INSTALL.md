install ansible
# สร้าง SSH key ถ้ายังไม่มี
ssh-keygen -t rsa -b 4096

# Copy SSH key ไปยังทุกเครื่อง
ssh-copy-id root@10.0.1.10  # master-01
ssh-copy-id root@10.0.1.20  # worker-01
ssh-copy-id root@10.0.1.21  # worker-02