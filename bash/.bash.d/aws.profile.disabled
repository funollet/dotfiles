# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <https://unlicense.org>

# There are lots of well-built tools that completely manage your
# AWS profiles and login and credentials, like aws-vault and AWSume.
# This isn't that.
# I tend to prefer to go as lightweight as possible around AWS-produced tools.
# So all this does is set and unset your AWS_PROFILE environment variable.

# You might also be interested in aws-whoami
# which improves upon `aws sts get-caller-identity`
# https://github.com/benkehoe/aws-whoami

aws-profile () {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "USAGE:"
    echo "aws-profile              <- print out current value"
    echo "aws-profile PROFILE_NAME <- set PROFILE_NAME active"
    echo "aws-profile --unset      <- unset the env vars"
  elif [ -z "$1" ]; then
    if [ -z "$AWS_PROFILE$AWS_DEFAULT_PROFILE" ]; then
      echo "No profile is set"
      return 1
    else
      echo "$AWS_PROFILE$AWS_DEFAULT_PROFILE"
    fi
  elif [ "$1" = "--unset" ]; then
    AWS_PROFILE=
    AWS_DEFAULT_PROFILE=
    # removing the vars is needed because of https://github.com/aws/aws-cli/issues/5016
    export -n AWS_PROFILE AWS_DEFAULT_PROFILE
  else
    # this check needed because of https://github.com/aws/aws-cli/issues/5546
    if ! aws configure list-profiles | grep --color=never -Fxq -- "$1"; then
      echo "$1 is not a valid profile"
      return 2
    else
      AWS_DEFAULT_PROFILE=
      export AWS_PROFILE=$1
      export -n AWS_DEFAULT_PROFILE
    fi;
  fi;
}
# completion is kinda slow, operating on the files directly would be faster but more work
# aws configure list-profiles is only available with the AWS CLI v2. You should use v2.
_aws-profile-completer () {
  COMPREPLY=(`aws configure list-profiles | grep --color=never ^${COMP_WORDS[COMP_CWORD]}`)
}
complete -F _aws-profile-completer aws-profile