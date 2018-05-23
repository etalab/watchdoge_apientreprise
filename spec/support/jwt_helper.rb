module JwtHelper
  def self.jwt(type = :valid)
    samples = {
      fake_role: 'eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiIxZTBmMjFjZi0wZDQ3LTQ1OTQtODlhZS0xNzJkMGFjNDAwMWUiLCJqdGkiOiIzNTNhNDc5NC1mYmFhLTRhNDctOTRiNC0wZDhkMzUxYzEwYTgiLCJyb2xlcyI6WyJmYWtlIl0sInN1YiI6IlRFU1QiLCJpYXQiOjE1MjU5Nzg1MTJ9.pkCU2W4lfvpwQp558LVEC0XriVpKEvks-QzgOcV2x7o',
      valid: 'eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiIxZTBmMjFjZi0wZDQ3LTQ1OTQtODlhZS0xNzJkMGFjNDAwMWUiLCJqdGkiOiJkZDMxNDljYy01NTQ3LTQ2YWEtOGY3Mi0zNGJmNjNkOGY3ZjgiLCJyb2xlcyI6WyJqd3Rfc3RhdGlzdGljcyJdLCJzdWIiOiJURVNUIiwiaWF0IjoxNTI1OTcxMTEzfQ.fS4WThvhe4Qmw_Yy1vDGPPaf0MGk9XXlT9DUh7Sc7ig',
      forged: 'eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiI0YzYzYzlkOS0xOGRjLTRhNjMtYTU1NS1kZTg3ZjY0M2YyYzAiLCJyb2xlcyI6WyJyb2wzIiwicm9sNCJdfQ.28Zo8dOMOxd4G5-nR-sfmNlbqRnSvbRbVkVto6i50gI',
      corrupted: 'eyJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiI0YzYzYzlkOS0xOGRjLTRhNjMtYTU1NSgdfgd1kZTg3ZjY0M2YyYzAiLCJyb2xlcyI6WyJyb2wzIiwicm9sNCJdfQ.28Zo8dOMOxd4G5-nR-sfmNlbqRnSvbRbVkVto6i50gI'
    }

    samples[type]
  end
end