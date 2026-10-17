import os
import pytest

from dotenv import load_dotenv

from mypackage.mymodule import myfunc

# read .env
load_dotenv(
  dotenv_path=os.path.join(os.path.dirname(__file__), "..", ".env")
)

