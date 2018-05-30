module JwtHelper
  def self.api(type = :valid)
    samples = {
      # UID: ef0b01d-00c9-49a3-ab8c-3f77700e3bd2
      # VCR_REGEN: change it to Watchdoge JWT to regenerate VCR cassettes
      valid: 'eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiJlZWYwYjAxZC0wMGM5LTQ5YTMtYWI4Yy0zZjc3NzAwZTNiZDIiLCJqdGkiOiJhNDBiMmMxZi0xOWFhLTQ4ZGYtOGJiMy1jNWEzMTZjYWUyZjgiLCJyb2xlcyI6WyJhdHRlc3RhdGlvbnNfYWdlZmlwaCIsImF0dGVzdGF0aW9uc19maXNjYWxlcyIsImF0dGVzdGF0aW9uc19zb2NpYWxlcyIsImNlcnRpZmljYXRfY25ldHAiLCJhc3NvY2lhdGlvbnMiLCJjZXJ0aWZpY2F0X29wcWliaSIsImRvY3VtZW50c19hc3NvY2lhdGlvbiIsImV0YWJsaXNzZW1lbnRzIiwiZW50cmVwcmlzZXMiLCJleHRyYWl0X2NvdXJ0X2lucGkiLCJleHRyYWl0c19yY3MiLCJleGVyY2ljZXMiLCJsaWFzc2VfZmlzY2FsZSIsImZudHBfY2FydGVfcHJvIiwicHJvYnRwIiwibXNhX2NvdGlzYXRpb25zIl0sInN1YiI6IkRldiBXYXRjaGRvZ2UiLCJpYXQiOjE1Mjc2MTI1NTJ9.fuMdE1eVKcUnXxBAn7cYZsoeO4Qe2VVt0eTv-pq3KS0',
      another_valid: 'eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiI0YTIxN2RkOS00YWNlLTRjMzItOTA5Ni0xZDMzMjI0OWI5OWMiLCJqdGkiOiI4NWMxYWRjYy0wNDVmLTRmNTMtYTcyOS1iYzY5ZGI4NWU4MDMiLCJyb2xlcyI6WyJhdHRlc3RhdGlvbnNfYWdlZmlwaCIsImF0dGVzdGF0aW9uc19zb2NpYWxlcyIsImNlcnRpZmljYXRfY25ldHAiLCJhc3NvY2lhdGlvbnMiLCJjZXJ0aWZpY2F0X29wcWliaSIsImRvY3VtZW50c19hc3NvY2lhdGlvbiIsImV0YWJsaXNzZW1lbnRzIl0sInN1YiI6IlRlc3QiLCJpYXQiOjE1Mjc2MTQyNTd9.fWaWj_1moYqAf8fNKzBjHLSLsF1pvQ1TtNVJ2MvVkos',
      fake_role: 'eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiIxZTBmMjFjZi0wZDQ3LTQ1OTQtODlhZS0xNzJkMGFjNDAwMWUiLCJqdGkiOiIzNTNhNDc5NC1mYmFhLTRhNDctOTRiNC0wZDhkMzUxYzEwYTgiLCJyb2xlcyI6WyJmYWtlIl0sInN1YiI6IlRFU1QiLCJpYXQiOjE1MjU5Nzg1MTJ9.pkCU2W4lfvpwQp558LVEC0XriVpKEvks-QzgOcV2x7o',
      forged: 'eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiI0YzYzYzlkOS0xOGRjLTRhNjMtYTU1NS1kZTg3ZjY0M2YyYzAiLCJyb2xlcyI6WyJyb2wzIiwicm9sNCJdfQ.28Zo8dOMOxd4G5-nR-sfmNlbqRnSvbRbVkVto6i50gI',
      corrupted: 'eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiI0YzYzYzlkOS0xOGRjLTRhNjMtYTU1NSgdfgd1kZTg3ZjY0M2YyYzAiLCJyb2xlcyI6WyJyb2wzIiwicm9sNCJdfQ.28Zo8dOMOxd4G5-nR-sfmNlbqRnSvbRbVkVto6i50gI'
    }

    samples[type]
  end

  def self.session(type = :valid)
    samples = {
      # UID: eef0b01d-00c9-49a3-ab8c-3f77700e3bd2
      # valid & admin are valid for 10 years
      valid: 'eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiJlZWYwYjAxZC0wMGM5LTQ5YTMtYWI4Yy0zZjc3NzAwZTNiZDIiLCJncmFudHMiOltdLCJpYXQiOjE1Mjc2ODEwODgsImV4cCI6MTg0MzI1NzA4OH0.jdWScu6sqlVjO9wtna2RoMGtuG-d-bEaNpk8AYZr55Q',
      admin: 'eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiJlZWYwYjAxZC0wMGM5LTQ5YTMtYWI4Yy0zZjc3NzAwZTNiZDIiLCJncmFudHMiOltdLCJpYXQiOjE1Mjc2ODAyMTgsImV4cCI6MTg0MzI1NjIxOH0.rWfEMDJMN-q63NnhhrVSJGefv5Z-nCshLz7eUO3ysEE',
      expired: 'eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiJlZWYwYjAxZC0wMGM5LTQ5YTMtYWI4Yy0zZjc3NzAwZTNiZDIiLCJncmFudHMiOltdLCJpYXQiOjE1Mjc2MTI3OTYsImV4cCI6MTUyNzYyNzE5Nn0.NfoSlNcbNPdGlPO_3-tIbXV66k7M3whmnOA2OTLr16o',
      forged: 'eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiJlZWYwYjAxZC0wMGM5LTQ5YTMtYWI4Yy0zZjc3NzAwZTNiZDIiLCJncmFudHMiOltdLCJpYXQiOjE1Mjc2MTI3OTYsImV4cCI6MTUyNzYyNzE5Nn0.NfoSlNcbNPdGlPO_3-tIbXV66k7M3whmnOA2Ogegefge',
      corrupted: 'eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiJlZWYwYjAxZC0wMGM5LTQ5YTMtYWI4Yy0zZjc3NzAwZTNiZDIiLCJncmFudHMiOltdLCJpYXQiOjE1Mjc2MTI3OTYsImVNzE5Nn0.NfoSlNcbNPdGlPO_3-tIbXV66k7M3whmnOA2OTLr16o'
    }

    samples[type]
  end

  def self.valid_jti
    # JTI: a40b2c1f-19aa-48df-8bb3-c5a316cae2f8
    jwt = api(:valid)
    JwtService.new(jwt: jwt).jwt_api_entreprise.jti
  end
end
