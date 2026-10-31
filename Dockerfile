# syntax=docker/dockerfile:1
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    MCP_TRANSPORT=streamable-http \
    MCP_HOST=0.0.0.0 \
    MCP_PORT=8000 \
    MCP_PATH=/mcp \
    COMFY_MCP_REMOTE_SHARED_MODELS=1 \
    WORKFLOW_DIR=/app/workflows

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml README.md LICENSE NOTICE ./
COPY src ./src

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip && \
    pip install "comfy-cli>=1.14" .

# 在容器內建立 comfy-cli 所需的 ComfyUI workspace 結構，不污染宿主機
RUN mkdir -p /comfy/ComfyUI/comfy /comfy/ComfyUI/comfy_extras /comfy/ComfyUI/models /comfy/ComfyUI/output /app/workflows && \
    touch /comfy/ComfyUI/main.py /comfy/ComfyUI/nodes.py && \
    comfy --skip-prompt tracking disable && \
    comfy set-default /comfy/ComfyUI

EXPOSE 8000

CMD ["comfy-mcp"]
