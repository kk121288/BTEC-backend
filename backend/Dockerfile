FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
# Ensure application package is importable for tests
ENV PYTHONPATH=/app
# غيرنا المنفذ ليتوافق مع إعداداتنا السابقة
EXPOSE 10000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "10000"]