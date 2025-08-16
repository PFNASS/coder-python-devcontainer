#!/usr/bin/env python3
import os
import sys
import shutil
from pathlib import Path
from textwrap import dedent

TEMPLATE_FILES = {
    ".gitignore": dedent("""\
        __pycache__/
        .env
        .DS_Store
        .idea/
        .vscode/
        """),
    "README.md": "# {name}\n\nA CrewAI project.\n",
    "pyproject.toml": dedent("""\
        [tool.poetry]
        name = "{name}"
        version = "0.1.0"
        description = ""
        authors = ["Your Name <you@example.com>"]

        [tool.poetry.dependencies]
        python = "^3.10"
        crewai = "*"

        [build-system]
        requires = ["poetry-core>=1.0.0"]
        build-backend = "poetry.core.masonry.api"
        """),
    ".env": "# Add your environment variables here, e.g.:\n# OPENAI_API_KEY=\n",
    "src/__init__.py": "",
    "src/crew.py": dedent("""\
        from crewai.project import CrewBase, crew, agent, task

        @CrewBase
        class {class_name}Crew:
            pass
        """),
    "src/main.py": dedent("""\
        if __name__ == "__main__":
            print("Run your crew with: crewai run")
        """),
    "src/tools/__init__.py": "",
    "src/tools/custom_tool.py": dedent("""\
        def example_tool():
            \"\"\"Example custom tool.\"\"\"
            pass
        """),
    "src/config/agents.yaml": dedent("""\
        # Define your agents here
        # Example:
        # researcher:
        #   role: "Researcher"
        #   goal: "Find info"
        #   backstory: "You are detail oriented."
        """),
    "src/config/tasks.yaml": dedent("""\
        # Define your tasks here
        # Example:
        # task1:
        #   description: "Do something"
        #   agent: researcher
        """),
}

def create_crewai_project(project_name: str):
    root = Path(project_name)
    if root.exists():
        print(f"Error: '{project_name}' already exists.")
        sys.exit(1)

    dirs = [
        root,
        root / "src" / project_name,
        root / "src" / "tools",
        root / "src" / "config",
    ]
    for d in dirs:
        d.mkdir(parents=True, exist_ok=True)
        (d / ".gitkeep").write_text("")  # Keep empty dirs under version control

    for rel_path, content in TEMPLATE_FILES.items():
        path = root / rel_path.format(name=project_name, class_name=project_name.capitalize())
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content.format(name=project_name, class_name=project_name.capitalize()))

    print(f"Created CrewAI project '{project_name}'.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: create_crewai.py <project_name>")
        sys.exit(1)
    project = sys.argv[1]
    create_crewai_project(project)
